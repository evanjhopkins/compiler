
### Compiler in swift
Note, the compiled compiler lives in the bin folder of this repo: "bin/compiler". Feel free to recompile it from the source if you desire.


## Instructions to Run
If you would like to run source from a file, you can do it:  
   ```cat your_source_file.txt | ./bin/compiler```

You may also type your source directly in the command line in the following way:  
   ```echo "{print(5)}$" | ./bin/compiler```

## Verbose
You can toggle verbose mode by add a "-v" flag when running the compiler   
   ```cat your_source_file.txt | ./bin/compiler -v```
