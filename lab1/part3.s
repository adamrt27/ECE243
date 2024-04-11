.global _start
_start:
   movi r1, 1 /* put 1 in r1 */
   movi r3, 29
   movi r2, 0
   movi r12, 0
   
LOOP:
   add r2, r1, r2 /* store current value of loop in r2 */
   add r12, r12, r2 /* add r2 to r12 */
   ble r2, r3, LOOP /* loops back to start of loop if current counter value less than 30 */
   
done: br done