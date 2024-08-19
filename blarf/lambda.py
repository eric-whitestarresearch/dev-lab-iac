import boto3

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
  instances_to_stop = [instance['InstanceId'] for instance in response['Reservations'][0]['Instances'] ]
  stop_response = ec2_client.stop_instances(
    InstanceIds = instances_to_stop
  )
print(instances_to_stop)