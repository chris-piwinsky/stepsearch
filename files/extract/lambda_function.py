import json
import wrapper
import os
import os_function
from opensearchpy import OpenSearch, helpers
from opensearchpy.helpers import bulk

password = None
client = None


def lambda_handler(event, context):
    global password
    global client
    
    print(f"Event: {json.dumps(event)}")
    # Retrieve the input from the event object
    input_data = event.get('input')

    print('input_data', input_data)

    if password is None:
        print('in password lookup')
        password = wrapper.get_password()
    if client is None:
        print('in OS connection')
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
