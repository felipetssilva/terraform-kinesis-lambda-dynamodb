import json
import datetime
import random
import boto3
session=boto3.Session(aws_access_key_id='AKIAWL7YZGQAHSMKSAQX',aws_secret_access_key='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', region_name='us-east-1')

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