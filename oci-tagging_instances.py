import pandas as pd
import os
import oci
from prettytable import PrettyTable
# setting config path, default path is ~/.oci/config (make sure not on VPN)
from oci.config import from_file

# validating configuration file, making sure the connection is established
config = from_file(profile_name="default")

computeClient = oci.core.ComputeClient(config)
identityClient = oci.identity.IdentityClient(config)
user = identityClient.get_user(config["user"]).data


##########################################################################
# Update the instances in compartment
##########################################################################


def compute():
    print(f"============Loading the instances in {compt.name}=============")
    for computeInstance in computeInstances.data:
        if computeInstance.lifecycle_state == "RUNNING":
            print('Display Name: ', computeInstance.display_name)
            df = pd.read_excel('document.xlsx', sheet_name='Tag',
                               index_col=False, dtype=str)
            for i in range(len(df)):
                if df.loc[i, "instance_name"] == computeInstance.display_name:
                    update_instance_response = computeClient.update_instance(
                        instance_id=computeInstance.id,
                        update_instance_details=oci.core.models.UpdateInstanceDetails(
                            defined_tags={
                                'testing': {
                                    'product_type': df.loc[i, "product_version"],
                                    'customer_name': df.loc[i, "customer"]}},
                        ))
                    print(
                        f"Finished updating tag in {computeInstance.display_name}")


##########################################################################
# Printing the instances in compartment
##########################################################################
def printing():
    title = '\nOCI Report of Compute Instances in Compartment: ' + compt.name + '\n'
    print(title)
    x = PrettyTable()
    x.field_names = ['Display Name', 'Shape', 'Defined Tags',
                     'DF_Product_type', 'DF_Customer_name']
    for computeInstance in computeInstances.data:
        if computeInstance.lifecycle_state == "RUNNING":
            x.add_row([computeInstance.display_name,
                      computeInstance.shape, computeInstance.defined_tags, computeInstance.defined_tags.get('testing')['product_type'], computeInstance.defined_tags.get('testing')['customer_name']])
    print(x)


##########################################################################
# Get the Compartment we want
##########################################################################
rootCompartmentID = user.compartment_id
user_inp = input("Enter the compartment name to tag: ")
comptList = identityClient.list_compartments(
    compartment_id=rootCompartmentID, compartment_id_in_subtree=True, access_level="ACCESSIBLE")
# print(comptList.data)
# Get the Compartment we want
if comptList:
    for compt in comptList.data:
        # if compt.name in 'sandbox':
        if compt.name in user_inp:
            computeInstances = computeClient.list_instances(compt.id)
            compute()
            printing()
            break
        else:
            continue
