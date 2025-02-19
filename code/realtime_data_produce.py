import json
import datetime
import random
import boto3
import boto3
import os

session = boto3.Session(
    aws_access_key_id=os.environ['AWS_ACCESS_KEY'],
    aws_secret_access_key=os.environ['AWS_SECRET_KEY'],
    region_name=os.environ['AWS_REGION']
)
client = session.client('kinesis')


def getData(dataName, lowVal, highVal):
   data = {}
   data["datasetName"] = dataName
   data["datasetValue"] = random.randint(lowVal, highVal) 
   return data

temp=0;

while temp<1000:
   rnd = random.random()
   if (rnd < 0.01):
      data = json.dumps(getData("DemoData", 100, 120))  
      client.put_record(StreamName="realtime_data_stream", Data=data, PartitionKey="1")
      print('*************************** anomaly *********************** ' + data)
   else:
      data = json.dumps(getData("DemoData", 10, 20))  
      client.put_record(StreamName="realtime_data_stream", Data=data, PartitionKey="1")
      print(data)
   temp=temp+1