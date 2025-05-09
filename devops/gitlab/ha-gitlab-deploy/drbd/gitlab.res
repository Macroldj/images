resource gitlab {
        meta-disk internal;
        device /dev/drbd0;

        on gitlab-node1 {
                device /dev/drbd0;
                disk /dev/mapper/data-main;
                address 100.64.10.227:7788;
                meta-disk internal;
        }
        on gitlab-node2 {
                device /dev/drbd0;
                disk /dev/mapper/data-main;
                address 100.64.10.229:7788;
                meta-disk internal;
        }
}