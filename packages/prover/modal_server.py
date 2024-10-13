import modal
import logging
from google.cloud.logging import Client
from google.cloud.logging.handlers import CloudLoggingHandler
from google.cloud.logging_v2.handlers import setup_logging
from google.oauth2 import service_account

app = modal.App("jwt-prover-v0.1.4")

image = modal.Image.from_dockerfile("Dockerfile")


@app.function(
    image=image,
    mounts=[
        modal.Mount.from_local_python_packages("core"),
    ],
    cpu=16,
    secrets=[modal.Secret.from_name("gc-ether-email-auth-prover")],
)
@modal.wsgi_app()
def flask_app():
    from flask import Flask, request, jsonify
    import random
    import sys
    import json
    import os
    from core import (
        gen_jwt_proof,
    )

    app = Flask(__name__)
    service_account_info = json.loads(os.environ["SERVICE_ACCOUNT_JSON"])
    credentials = service_account.Credentials.from_service_account_info(
        service_account_info
    )
    logging_client = Client(project="zkairdrop", credentials=credentials)
    print(logging_client)
    handler = CloudLoggingHandler(logging_client, name="jwt-prover")
    print(handler)
    setup_logging(handler)

    @app.post("/prove/jwt")
    def prove_jwt():
        print("jwt")
        req = request.get_json()
        input = req["input"]
        logger = logging.getLogger(__name__)
        logger.info(req)
        print(req)
        nonce = random.randint(
            0,
            sys.maxsize,
        )
        logger.info(nonce)
        print(nonce)
        proof = gen_jwt_proof(str(nonce), False, input)
        logger.info(proof)
        print(proof)
        return jsonify(proof)

    return app
