import json
import wrapper
import os
import os_function
from opensearchpy import OpenSearch, helpers
from opensearchpy.helpers import bulk

def lambda_handler(event, context):
    print(f"Event: {json.dumps(event)}")
    # Retrieve the input from the event object
    input_data = event.get('input')
    
    print('input_data', input_data)
    
    password = wrapper.get_password()
    client = os_function.connect(password)

    response_body = ""
    status_code = 0
    try:   
        resp = client.search(
        index="recipes",
        body={
            "query": {
                "match_all": {}
            },
        },
        size=5
        )

        selected_documents = resp['hits']['hits']

        # Print the selected documents
        for doc in selected_documents:
            print(doc['_source'])


        print('Search Response: ', selected_documents)
        response_body = selected_documents
        status_code = 200

    except Exception as e:
        print("Create error occurred:", str(e))
        status_code = 500
        response_body = str(e)

    # Construct the response
    response = {
        'statusCode': status_code,
        'body': json.dumps(response_body),
        'headers': {
            'Content-Type': 'application/json'
        }
    }

    return response
