# 

# Step 1, convert source "u-boot-cmd-usb_test.txt" to uboot output file "x1"
./cvt-cmd-4-screen.sh u-boot-cmd-usb_test.txt x1

# Step 2, send "x1" to screen #2 only 
./file-cmd-2-screen.sh x1 2
