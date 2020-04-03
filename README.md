# homura-stopwatch

input

~~~shell
echo "10:30 10:40 tvirus, 10:40 12:28 icbm, 12:28 14:59 gsomia, 15:41 15:57 gsomia, 15:57 16:35 panzer, 16:35 17:17 icbm, 17:17 17:28 gsomia, 17:28 18:15 icbm, 18:15 18:42 gsomia, 18:42 19:44 icbm, 19:44 20:04 gsomia, 20:04 21:10 icbm, 22:10 23:27 icbm" | homura-stopwatch
~~~

output

~~~shell
tvirus	0:10
icbm	6:42
gsomia	3:45
panzer	0:38
~~~

区切りは`,`でも`\n`でもOKです.
