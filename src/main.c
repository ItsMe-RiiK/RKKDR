#include "features/autoclicker/autoclicker.h"
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Syakir");
MODULE_DESCRIPTION("A simple Linux kernel module");
MODULE_VERSION("0.1");

static int __init my_kernel_driver_init(void)
{
  printk(KERN_INFO "[KERNEL_DRIVER]: Module loaded.\n");
  return autoclicker_init();
}

static void __exit my_kernel_driver_exit(void)
{
  autoclicker_exit();
  printk(KERN_INFO "[KERNEL_DRIVER]: Module unloaded.\n");
}

module_init(my_kernel_driver_init);
module_exit(my_kernel_driver_exit);
