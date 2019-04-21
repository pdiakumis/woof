version 1.0

task echoHello{
    command {
        echo "Hello AWS! This is Peter!"
    }
    runtime {
        docker: "ubuntu:latest"
    }

}

workflow printHelloAndGoodbye {
    call echoHello
}

