import boto3
from time import sleep

first_ec2_client = boto3.client('ec2')
first_ec2_client_response = first_ec2_client.describe_instances(
  Filters = [
    {
      'Name' : 'tag:microk8s_cluster',
      'Values' : [
        'lf_dev'
      ],
    },
    {
      'Name' : 'tag:k8s_role',
      'Values' : [
        'first'
      ],
    }
  ]
)

if first_ec2_client_response['Reservations']:
  first_k8s_instance_id = [instance['InstanceId'] for instance in first_ec2_client_response['Reservations'][0]['Instances'] ]
  # TODO put some retry loging if the command failed. It could fail because we are still waiting for the first node to come up if we are doing this on a cold start. 

print(first_k8s_instance_id)

first_ssm_client = boto3.client('ssm')
first_ssm_response = first_ssm_client.send_command(
  InstanceIds = first_k8s_instance_id,
  TimeoutSeconds=120,
  DocumentName="AWS-RunShellScript",
  Parameters={'commands': ['microk8s add-node --format short']}, 
)

commandid = first_ssm_response['Command']['CommandId']

sleep(3) #Need a little bit of sleep to wait for the command invocation to create. 

first_command_result = first_ssm_client.get_command_invocation(
  CommandId = commandid,
  InstanceId = first_k8s_instance_id[0]
)

if first_command_result['Status'] == 'Success':
  new_node_token = first_command_result['StandardOutputContent']

print(new_node_token)


  


