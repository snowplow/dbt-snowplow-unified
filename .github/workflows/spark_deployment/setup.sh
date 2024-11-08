
#!/bin/bash

# Create a new spark-defaults.conf with substituted values
sed -e "s|\${AWS_ACCESS_KEY_ID}|$AWS_ACCESS_KEY_ID|g" \
    -e "s|\${AWS_SECRET_ACCESS_KEY}|$AWS_SECRET_ACCESS_KEY|g" \
    /spark/conf/spark-defaults.conf.template > /spark/conf/spark-defaults.conf
# Execute the passed command
exec "$@"