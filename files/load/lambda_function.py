import json
import os

def lambda_handler(event, context):
    # Retrieve the input from the event object
    input_data = event.get('extract_output')
    
    print('input_data', input_data)

    return {
        'statusCode': 200,
        'body': input_data
    }