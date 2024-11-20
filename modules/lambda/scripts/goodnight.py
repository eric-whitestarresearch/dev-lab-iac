import boto3

def find_running_instances():
  """
  Find running instances

  Parameters:
    None
  
  Return:
    Dict : A dictornary 
    
    Schema: instances_to_stop: List(string) Instance ids of instances that don't support hibernation and will require a stop
            instances_to_hibernate: List(String) Instance ids of instances that support hibernation and can be suspended
  """
  ec2_client = boto3.client('ec2')
  response = ec2_client.describe_instances(
    Filters = [
      {
        'Name' : 'instance-state-name',
        'Values' : [
          'running'
        ],
      }
    ]
  )

  if response['Reservations']:
    instances_to_hibernate = [instance['Instances'][0]['InstanceId'] for instance in response['Reservations'] if instance['Instances'][0]['HibernationOptions']['Configured'] ]
    instances_to_stop = [instance['Instances'][0]['InstanceId'] for instance in response['Reservations'] if not instance['Instances'][0]['HibernationOptions']['Configured'] ]
    
    return {
    "instances_to_stop" : instances_to_stop,
    "instances_to_hibernate": instances_to_hibernate
    }
  
  return {
    "instances_to_stop" : [],
    "instances_to_hibernate": []
    }
  
def find_running_rds_instances():
  """
  Find running RDS instances

  Parameters: 
    None

  Return
    List of instance IDs
  """
  rds_client = boto3.client('rds')
  response = rds_client.describe_db_instances()

  return [r['DBInstanceIdentifier'] for r in response['DBInstances'] if r['DBInstanceStatus'] == 'available']

def stop_rds_instances(instances):
  """
  Stop the RDS instnaces

  Parameters:
    instances (List(string)): A list of the RDS instances to start or stop
  """
  rds_client = boto3.client('rds')
  for i in instances:
    rds_client.stop_db_instance(DBInstanceIdentifier=i)

def stop_instances(instances, hibernate=False):
  """
  Stop or hibernate and instance

  Parameters:
    instances (List(string)): A list of the instances to start or stop
    hibernate (Bool): If True then hibernate the instances, If False then stop the instances
  """
  ec2_client = boto3.client('ec2')

  ec2_client.stop_instances(
    InstanceIds = instances,
    Hibernate = hibernate
  )

  return

def lambda_handler(event, context):
  """
  The entry point for the lambda function

  Parameters:
    event (Dict): The details of the event that triggered the lambda
    context (Dict): The context of the lambda execution

  Return:
    Dict: A dictonary wih the http status code and a body to describe this execution
  """
  target_instances = find_running_instances()
  rds_target_instances = find_running_rds_instances()

  if len(target_instances["instances_to_stop" ]) > 0 :
    stop_instances(instances = target_instances["instances_to_stop" ], hibernate = False)
  if len(target_instances["instances_to_hibernate" ]) > 0 :
    stop_instances(instances = target_instances["instances_to_hibernate" ], hibernate = True)
  if len(rds_target_instances) > 0:
    stop_rds_instances(rds_target_instances)

  return {
      'statusCode': 200,
      'body': {"ec2": target_instances, "rds": rds_target_instances}
    }