import boto3
from time import sleep
import json

class InstanceNotFound(BaseException):
  pass

class SSMCommandFailure(BaseException):
  pass

class ClusterTagNotFound(BaseException):
  pass

def get_cluster_name_for_node(instance_id):
  ec2_client = boto3.client('ec2')
  ec2_client_response = ec2_client.describe_instances(
    InstanceIds = [instance_id]
  )

  cluster_name = [tag['Value'] for tag in ec2_client_response['Reservations'][0]['Instances'][0]['Tags'] if 'microk8s_cluster' in tag['Key']]

  if len(cluster_name) == 1:
    return cluster_name[0]
  else: 
    raise ClusterTagNotFound(f"Could not find the cluster name tag on instance f{instance_id}, does the tag microk8s_cluster exist?")

def find_node(cluster_name, role, instance_id):
  filters = [
    {
      'Name' : 'tag:microk8s_cluster',
      'Values' : [
        cluster_name
      ],
    },
    {
      'Name' : 'tag:k8s_role',
      'Values' : [
        role
      ],
    },
    {
      'Name' : 'instance-state-name',
      'Values' : [
        'running'
      ],
    }
  ]

  ec2_client = boto3.client('ec2')
  if instance_id:
    ec2_client_response = ec2_client.describe_instances(
      Filters = filters,
      InstanceIds = [instance_id]
    )
  else:
    ec2_client_response = ec2_client.describe_instances(
      Filters = filters
    )

  if ec2_client_response['Reservations']:
    return [instance['InstanceId'] for instance in ec2_client_response['Reservations'][0]['Instances']][0]
  else:
    return None

def run_ssm_command(instance_id, command):
  #Run the node add command to get the token against the first node in the cluster
  ssm_client = boto3.client('ssm')
  ssm_response = ssm_client.send_command(
    InstanceIds = [instance_id],
    TimeoutSeconds=120,
    DocumentName="AWS-RunShellScript",
    Parameters={'commands': [command]}, 
  )

  commandid = ssm_response['Command']['CommandId']

  sleep(3) #Need a little bit of sleep to wait for the command invocation to create. 

  command_result = ssm_client.get_command_invocation(
    CommandId = commandid,
    InstanceId = instance_id
  )

  
  if command_result['Status'] in ['Success', 'InProgress']:
    return command_result
  else:
    raise SSMCommandFailure(f"Failed to run command {command} on instance {instance_id} Output {command_result['StandardErrorContent']}")



def lambda_handler(event, context):
  cluster_name = get_cluster_name_for_node(event['new_node'])

  #Find the instance that we want to run the add node against
  first_node_instance_id = find_node(cluster_name, 'first', None)

  if not first_node_instance_id:
    raise InstanceNotFound(f"Could not find the first node for the cluster {cluster_name}")
  

  #The node that invoked this is the first node in the cluster. We can just ignore this request.
  if first_node_instance_id == event['new_node']:
    return {
      'statusCode': 208, 
      'body': json.dumps('This node is the first node in the cluster, ignoring')
    }
  
  #If new node is worker put that in the command
  gen_node_token_command = 'microk8s add-node --format short'
  
  add_new_node_command = run_ssm_command(first_node_instance_id, gen_node_token_command)['StandardOutputContent']


  #Is the new node a worker?
  if find_node(cluster_name, 'worker', event['new_node']):
    add_new_node_command = add_new_node_command.strip() + " --worker" 
  #Add the new node to the cluster
  add_new_result = run_ssm_command(event['new_node'], add_new_node_command)
  print(add_new_node_command)

  if add_new_result['Status'] == 'Success':
    return {
      'statusCode': 200,
      'body': json.dumps(f"Node {event['new_node']} added")
    }
  else:
    return {
      'statusCode': 500,
      'body': json.dumps(f"Failed to add node {event['new_node']}")
    }
  
