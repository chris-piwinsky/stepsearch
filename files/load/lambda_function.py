import logging
import traceback
import boto3
import os
from neo4j import GraphDatabase

ssm = boto3.client('ssm')

logging.getLogger().setLevel(logging.INFO)


def lambda_handler(event, context):
    logging.info("Running handler")

    # Connect to the Neo4j database and open a new session
    db_uri = ssm.get_parameter(Name='/Prod/Neo4j/uri')
    username = ssm.get_parameter(Name='/Prod/Neo4j/username')
    password = ssm.get_parameter(
        Name='/Prod/Neo4j/password', WithDecryption=True)

    uri = db_uri['Parameter']['Value']
    username = username['Parameter']['Value']
    password = password['Parameter']['Value']

    session = connect_db(uri, username, password)

    # Read data from the database
    treatment_data = read_from_db(session)

    # Close our database session
    disconnect_db(session)

    return (treatment_data)


def connect_db(uri, user, password):
    try:
        driver = GraphDatabase.driver(uri, auth=(user, password))
        session = driver.session()
    except Exception as error:
        msg = "".join(traceback.format_tb(error.__traceback__))
        logging.info(
            "error connecting to Neo4j database. %s:%s\n%s",
            type(error),
            error,
            msg,
        )
    logging.info("Successfully connected to Neo4j database")

    return session


def disconnect_db(session):
    logging.info("Closing Neo4j session")
    session.close()


def read_from_db(session):
    result = session.read_transaction(data_to_read)

    return result


def write_to_db(session):
    result = session.write_transaction(data_to_write)

    return result


def data_to_read(tx):
    cypher_query = '''
    CYPHER_QUERY
    '''

    result = tx.run(cypher_query)

    result_list = [record["field_name"] for record in result]

    return result_list


def data_to_write(tx):
    cypher_query = '''
    CYPHER_QUERY
    '''

    result = tx.run(cypher_query)

    result_list = [record["field_name"] for record in result]

    return result_list
