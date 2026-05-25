#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

#define FIFO_PATH "/tmp/eros_sensor_pipe"

int main(int argc, char *argv[]) {
    // Create FIFO if it doesn't exist
    mkfifo(FIFO_PATH, 0666);
    
    // Open in NON-BLOCKING mode. If Node C is choking, drop fruit to the floor.
    int fd = open(FIFO_PATH, O_WRONLY | O_NONBLOCK);
    if (fd == -1) {
        printf("Node C buffer full. Dropping telemetry to /dev/null.\n");
        return 1;
    }

    char *telemetry = "{\"sensor\":\"moen_flo\", \"flow_rate\": 3.14, \"timestamp\": 1716584210}\n";
    write(fd, telemetry, strlen(telemetry));
    close(fd);
    
    printf("Telemetry blasted successfully.\n");
    return 0;
}
