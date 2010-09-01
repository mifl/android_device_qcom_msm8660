#!/system/bin/sh

# Mount the firmware image files
mount -t ext3 -o remount,rw /dev/block/mmcblk0p12 /system

mkdir /system/etc/firmware/misc 2>/dev/null
mount -t vfat -o ro,shortname=lower /dev/block/mmcblk0p1 /system/etc/firmware/misc 2>/dev/null


# Check for images and set up symlinks
LOAD_MODEM=false
LOAD_QDSP=false

cd /system/etc/firmware/misc/image

# Force loading of modem and Q6 images
mkdir /data/modem 2>/dev/null
mkdir /data/modem/debug 2>/dev/null
mount -t debugfs debugfs /data/modem/debug

case `ls q6.mdt 2>/dev/null` in
    q6.mdt)
        LOAD_QDSP=true
        for imgfile in q6*; do
            ln -s /system/etc/firmware/misc/image/$imgfile /system/etc/firmware/$imgfile 2>/dev/null
        done
        break
        ;;
    *)
        log -p w -t PIL 8660 device but no q6 image found
        ;;
esac

cd /
if $LOAD_Q6; then
    log -p i -t PIL Initiating q6 load through PIL
    echo get > /data/modem/debug/pil/q6
fi

cd /system/etc/firmware/misc/image
case `ls modem.mdt 2>/dev/null` in
    modem.mdt)
        LOAD_MODEM=true
        for imgfile in modem*; do
            ln -s /system/etc/firmware/misc/image/$imgfile /system/etc/firmware/$imgfile 2>/dev/null
        done
        break
        ;;
    *)
        log -p w -t PIL 8660 device but no modem image found
        ;;
esac

cd /

mount -t ext3 -o remount,ro /dev/block/mmcblk0p12 /system

if $LOAD_MODEM; then
    log -p i -t PIL Initiating modem load through PIL
    echo get > /data/modem/debug/pil/modem
fi
