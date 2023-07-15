import os
import boto
from opensearchpy import OpenSearch, helpers
from opensearchpy.helpers import bulk

def connect(password):
    client = OpenSearch(
        hosts=[os.environ['OS_URI']],
        http_auth=(os.environ['MASTER_USER'], password),
        use_ssl=True,
        verify_certs=False,
        ssl_assert_hostname=False,
        ssl_show_warn=False,
    )
    client.info()
    return client

def create(client, index_name):
    client.indices.create(index_name)


def write_to_efs(data):
     # Configure the EFS file system and mount path
    efs_file_system_id = os.environ['EFS_ID']
    efs_mount_path = '/mnt/efs'
    
    # Read the data to be written
    data = "Hello, EFS!"
    
    # Create the EFS client
    efs_client = boto3.client('efs')
    
    # Get the EFS file system's mount target IP address
    response = efs_client.describe_file_systems(FileSystemIds=[efs_file_system_id])
    mount_target_ip = response['FileSystems'][0]['NumberOfMountTargets'][0]['IpAddress']
    
    # Mount the EFS file system
    mount_command = f"sudo mount -t efs {mount_target_ip}:/{efs_file_system_id} {efs_mount_path}"
    os.system(mount_command)
    
    # Write the data to the EFS mount
    file_path = f"{efs_mount_path}/data.txt"
    with open(file_path, 'w') as f:
        f.write(data)
    
    # Unmount the EFS file system
    unmount_command = f"sudo umount {efs_mount_path}"
    os.system(unmount_command)
    
    return {
        'statusCode': 200,
        'body': 'Data written to EFS successfully!'
    }