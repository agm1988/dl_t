# README

1. `master` branch contains an algorithm based on trivial SQL queries and further calculations with built-in Ruby methods. This option was implemented due to assumption that the amounts of data handled by Ruby would be comparatively small and with keeping SQL queries simple and efficient it probably would give the best performance.

2. Of course I gave it a try with the most job handled by Postgres and eventually it turned out to make 1.5-4 times better performance. This algorithm lives in `calc_slots_with_postgres` branch. See the [PR](https://github.com/v-tsvid/dl_t/pull/1) 

3. Anyway I believe what should be taken into account for making a choice between the two is the proper analysis and measuring on the real-world production system or similar. 

