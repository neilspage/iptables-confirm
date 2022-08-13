# iptables-confirm
Wrapper for iptables to prevent locking yourself out of a VM, or accidentally killing ssh. It uses a "confirm" mechanism and rollsback if a timeout expires.

## Example
Example: attempting to lock myself out of ssh ( 22/TCP ), however after the timeout expires, it rollsback iptables to its previous rules.
![image](https://user-images.githubusercontent.com/37527017/184476988-9a915975-fd5d-4363-b4a3-933e31e04228.png)
