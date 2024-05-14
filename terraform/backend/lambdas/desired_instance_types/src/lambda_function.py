import boto3
import logging
import json


logger = logging.getLogger()


def instance_family_compare_cost(famList,instances): 
    print("Recommended EC2 instances ")
    print("=====================")
    lowestCostList = []
    listIndex = -1
    prvlistIndex = -1
    for instance in instances['pricelist']:
        listIndex = listIndex + 1
        if instance['instanceFamily'] != famList:
            continue
        if prvlistIndex >= 0:
            if instances['pricelist'][prvlistIndex]['cost'] > instances['pricelist'][listIndex]['cost']:
                lowestCostList = instances['pricelist'][listIndex]
                prvlistIndex = listIndex
                continue
            if instances['pricelist'][prvlistIndex]['cost'] < instances['pricelist'][listIndex]['cost']:
                lowestCostList = instances['pricelist'][prvlistIndex]
                continue
            if instances['pricelist'][listIndex]['cost'] == instances['pricelist'][prvlistIndex]['cost']:
                str_storage=instances['pricelist'][prvlistIndex]['storage']
                if (str_storage.find('EBS') != -1):
                    lowestCostList = instances['pricelist'][prvlistIndex]
                    continue
                else:
                    lowestCostList = instances['pricelist'][listIndex]
        prvlistIndex = listIndex
    return lowestCostList


def get_cost_per_family(familyList,instances): 
    lowestCostList = []
    recommenedInstances = {}
    recommenedInstances['recommendedlist'] = []
    for famList in familyList:
        famList = famList.lstrip()
        famNum = 0
        listIndex = -1
        for instance in instances['pricelist']:
            if instance['instanceFamily'] != famList:
                listIndex = listIndex + 1
                continue
            famNum = famNum + 1
    ### one instnace and nothing to compare 
        if famNum == 1:
            lowestCostList=instances['pricelist'][listIndex]
            recommenedInstances['recommendedlist'].append(lowestCostList)
    ### multiple instance families found
        if famNum >= 1:
            lowestCostList=instance_family_compare_cost(famList,instances)
            recommenedInstances['recommendedlist'].append(lowestCostList)

    return recommenedInstances


def family_unique_list(tempList): 
    # intilize a null list 
    unique_list = []
    # traverse for all elements 
    for x in tempList:
        # check if exists in unique_list or not
        if x not in unique_list:
            unique_list.append(x)
    return unique_list


def get_instances_prices(cpu, memory, os):
    VCPU = cpu
    memory = memory
    MEMORY = memory + ' GiB'
    operatingSystem = os
    pricing = boto3.client('pricing')
    response = pricing.get_products(
        ServiceCode='AmazonEC2',
        Filters = [
           {'Type' :'TERM_MATCH', 'Field':'licenseModel',   'Value':'No License required'  },
           {'Type' :'TERM_MATCH', 'Field':'tenancy' ,      'Value':'Shared'       },
           {'Type' :'TERM_MATCH', 'Field':'preInstalledSw', 'Value':'NA'       },
           {'Type' :'TERM_MATCH', 'Field':'operatingSystem', 'Value':operatingSystem       },
           {'Type' :'TERM_MATCH', 'Field':'vcpu',            'Value':VCPU            },
           {'Type' :'TERM_MATCH', 'Field':'memory',          'Value':MEMORY          },
           {'Type' :'TERM_MATCH', 'Field':'location',        'Value':'US East (N. Virginia)'}
        ]
    )

    instances = {}
    instances['pricelist'] = []
    for pricelist in response['PriceList']:
        if (pricelist.find('per On Demand') == -1):
            continue
        product = json.loads(pricelist)
        productfamily = product['product']['productFamily']
        data = json.dumps(product['product'])
        attributes = json.loads(data)
        instanceFamily = attributes['attributes']['instanceFamily']
        instanceType = attributes['attributes']['instanceType']
        storage =  attributes['attributes']['storage']
        ### move up the json string
        data = json.dumps(product['terms'])
        terms = json.loads(data)
        data = json.dumps(terms['OnDemand'])
        terms = json.loads(data)
        for key in terms:
            data = terms[key]
        data1 = json.dumps(data)
        terms = json.loads(data1)
        data = json.dumps(terms['priceDimensions'])
        terms = json.loads(data)
        for key in terms:
            data = terms[key]
        for key in terms:
            data = terms[key]
        data1 = json.dumps(data)
        terms = json.loads(data1)
        pricePerUnit=(round(float(terms['pricePerUnit']['USD']),4))
        info = {"instanceFamily" : instanceFamily,"instanceType" : instanceType,"operatingSystem" : operatingSystem,"vcpu" : VCPU, "memory" : MEMORY,"storage" : storage, "cost" : pricePerUnit}

        if 'a1' not in info['instanceType'] and 'm6g' not in info['instanceType'] and 'c6g' not in info['instanceType'] and 'r6g' not in info['instanceType']:
            instances['pricelist'].append(info)

    ### sort by lowest cost
    familyList = []
    for instance in instances['pricelist']:
        familyList.append(str(instance['cost']) + ' : ' + instance['instanceFamily'])
    familyList.sort()
    # make a unique list
    tempList = []
    for InsFamily in familyList:
        tempList.append(InsFamily.split(':')[1])

    familyList = family_unique_list(tempList)
    recommended_list=get_cost_per_family(familyList,instances)
    instance_types = []
    instance_types.append(instances)
    instance_types.append(recommended_list)
  
    return instance_types
  
def lambda_handler(event, context):
    params = event['queryStringParameters']
    logger.setLevel("INFO")
    #########
    try:
        response=get_instances_prices(params['cpu'], params['memory'], params['os'])
        logging.info("Respnse - " + str(response))
    except BaseException as be:
        logging.exception("Error: Failed to process manage workstation request" + str(be))
        raise ChaliceViewError("Failed to process manage workstation request")

    return Response(body=response,
                    status_code=200,
                    headers={'Content-Type': 'application/json'})