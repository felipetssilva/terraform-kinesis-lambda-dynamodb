import boto3
import os
import base64
import uuid
import datetime

# Initialize DynamoDB and Kinesis resources and set up constants
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table_name = os.environ['DYNAMODB_TABLE']

def lambda_handler(event, context):
    print(event)
    for item in event['Records']:
        data = item['kinesis']['data']
        print("Raw data :",data);
        print("base64 decoded data :",base64.b64decode(data));
        print("UTF-8 decoded data :",base64.b64decode(data).decode('utf-8'));

        # Generate a new UUID (GUID)
        new_guid = uuid.uuid4()

        # Write data into DynamoDB
        table = dynamodb.Table(table_name)        
        item = {
            'id': str(new_guid),
            'timeStamp': str(datetime.datetime.now()),
            'utf8Value': base64.b64decode(data).decode('utf-8')
        }
        table.put_item(Item=item)
