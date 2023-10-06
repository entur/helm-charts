# Typical Backend

## Assumptions

Your application uses the default `PGUSER` and `PGPASSWORD` environment variables.
The contents of `my-secret-thing` is read as environment variables by the app.

### Postgres config

There should be a secret on this form:

    # typical-backend-psql-credentials
    data:
      PGPASSWORD: base64stuff
      PGUSER: base64stuff

There should be a configmap on this form:

    # typical-backend-psql-connection
    data:
      INSTANCES: project:region:dbname=tcp:5432  

## Configuration of note

* Ingress enabled, :80 -> :9000
* Use "/alive" as liveness probe, instead of the default `/actuator/health/liveness`
* Activate prometheus scraping on default probe `/actuator/prometheus`
* Rely on default probe for `/actuator/health/readiness`
* Two replicas minimum
* Two to six replicas for `prd`. HorizontalPodAutoscaler with default 80% target CPU
* Use `configmap` as a way to set environment variables. Common values in `values.yaml` and additional values in `values-kub-ent-$ENV.yaml`
* Pass some ENV variables (please consider using the `configmap` stanza.)
* Load secret `my-secret-thing` to the environment
* Activate postgres sidecar with specific requests for cpu and memory.
