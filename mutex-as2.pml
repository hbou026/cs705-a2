#define N 2 
byte pos[N];
byte mutex = 0; 
bit waiting[N];   // Track if a process is waiting to enter the critical section
byte turn = 0;    // Track whose turn it is (0 or 1)

/* Process P(i) */
proctype P(byte i) {
    do
    :: true ->
        waiting[i] = 1;

        // Wait for its turn to enter the critical section and check if the other process is waiting
        do
        :: (turn == i && mutex == 0) ->  // Process can enter when it is p[i] turn, mutex is 0
            // Enter CS
            mutex++;
            
            pos[i] = N;
            waiting[i] = 0;  

            // Simulate code in CS
            skip;

            // Exit from CS
            mutex--;
            pos[i] = 0;  
            turn = 1 - i;  // Pass the turn to the other process
            break; 
        :: (waiting[1 - i] == 1 && turn != i) ->  // Avoid race condition where both processes are waiting
            skip;  // Skip until the other process completes its turn
        :: else -> skip;  // Wait for the other process to finish or for its turn
        od;
    od;
}


proctype monitor() {
    do
    :: assert(mutex != 2)
    od
}


init {
    atomic {
        pos[0] = 0;
        pos[1] = 0;
        waiting[0] = 0;
        waiting[1] = 0;
        mutex = 0;
        turn = 0;    // Process 0 starts with the turn
        run P(0);
        run P(1);
        run monitor();
}
}

// LTL Properties 

/* Property 1: Multiple processes cannot enter the critical section together (Safety) */
ltl p1 { [] !(mutex == 2) }

/* Property 3: Any process not in the critical section will eventually enter (Liveness) */
ltl p3 { [] ( (pos[0] != N -> <> pos[0] == N) && (pos[1] != N -> <> pos[1] == N) ) }
