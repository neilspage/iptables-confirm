# iptables-confirm
Wrapper for iptables to prevent locking yourself out of a VM, or accidentally killing ssh. It uses a "confirm" mechanism and rollsback if a timeout expires.

## Example
Example: attempting to lock myself out of ssh ( 22/TCP ), however after the timeout expires, it rollsback iptables to its previous rules.
![image](https://user-images.githubusercontent.com/37527017/184477119-f0e45eaf-3ecc-4ad6-a7d7-a748a9dff567.png)

