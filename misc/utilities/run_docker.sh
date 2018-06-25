#!/bin/bash
if [ $(docker inspect -f '{{.State.Running}}' glm) = "false" ]; then
        echo 'glm container not running... I wake it up'
        docker start glm
fi

docker exec glm /home/AED_Tools/GLM/tests/1_Kariba/run.sh
