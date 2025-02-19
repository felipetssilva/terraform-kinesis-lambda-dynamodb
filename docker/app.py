import os
import boto3
from flask import Flask, request, jsonify

app = Flask(__name__)
# Environment variables set from Terraform/ECS container definition
dynamodb_table = os.getenv('DYNAMODB_TABLE')
kinesis_stream = os.getenv('KINESIS_STREAM')

# Initialize AWS clients (ensure your container’s IAM role has necessary permissions)
dynamodb = boto3.resource('dynamodb')
kinesis = boto3.client('kinesis')
table = dynamodb.Table(dynamodb_table)

@app.route('/send', methods=['POST'])
def send_data():
    data = request.json
    # Write data to DynamoDB
    table.put_item(Item=data)
    
    # Send data to Kinesis stream
    kinesis.put_record(
        StreamName=kinesis_stream,
        Data=str(data),
        PartitionKey="partitionKey"
    )
    
    return jsonify({"message": "Data sent"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)

