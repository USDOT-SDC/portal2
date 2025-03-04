import os
import jwt
import json
import requests


def get_verified_claims(event):
    headers = event["headers"]
    if "Authorization" not in headers:
        return {
            "hasError": True,
            "statusCode": 403,
            "body": {"errorMessage": "'Authorization' not present in headers"},
        }
    token = headers["Authorization"]
    response = requests.get(
        "https://cognito-idp."
        + os.environ.get("AWS_REGION")
        + ".amazonaws.com/"
        + os.environ.get("USER_POOL_ID")
        + "/.well-known/jwks.json",
        timeout=5,
    )
    if response.status_code != 200:
        return {
            "hasError": True,
            "statusCode": 403,
            "body": {"errorMessage": "Could not download JWKs."},
        }
    try:
        key_id = jwt.get_unverified_header(token)["kid"]
    except jwt.exceptions.DecodeError as e:
        return {
            "hasError": True,
            "statusCode": 401,
            "body": {"errorMessage": "Error verifying JWT: " + str(e)},
        }
    keys = response.json()["keys"]
    result_jwk = next((jwk for jwk in keys if jwk["kid"] == key_id), None)
    if result_jwk is None:
        return {
            "hasError": True,
            "statusCode": 403,
            "body": {"errorMessage": "No matching 'kid' in JWK list"},
        }
    key = jwt.algorithms.RSAAlgorithm.from_jwk(json.dumps(result_jwk))
    try:
        return {
            "hasError": False,
            "claims": jwt.decode(
                token,
                key=key,
                algorithms=["RS256"],
                audience=os.environ.get("APP_CLIENT_IDS").split(","),
            ),
        }
    except jwt.exceptions.InvalidTokenError as e:
        return {
            "hasError": True,
            "statusCode": 401,
            "body": {"errorMessage": "Error verifying JWT: " + str(e)},
        }
