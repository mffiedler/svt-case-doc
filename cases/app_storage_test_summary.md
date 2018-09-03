# Application storage test on OCP

## Resources

ec2: m5.xlarge instance

| app\params   | Max. instances | Min. PVC(Gi) | Min. Mem (Gi)         |
|--------------|----------------|--------------|-----------------------|
| amq          | 10             | 1            | n/a                   |
| fio          | ?              |              | n/a                   |
| git.workload | 8              | 3            | n/a                   |
| jenkins      | 2              | ?            | 4: 3 jobs; 6: 30 jobs |
| mongodb      | ?              |              |                       |
| mysql        | ?              |              |                       |
| postgresql   | ?              |              |                       |
| redis        | 2              | 3            | 6: workload_template  |
|              |                |              |                       |
