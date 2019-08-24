import std;
void main() {
	wait(spawnProcess("clear"));
	wait(spawnProcess(["dub", "test"]));
}
