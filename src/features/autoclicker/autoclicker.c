#include "autoclicker.h"
#include <linux/delay.h>
#include <linux/input.h>
#include <linux/module.h>
#include <linux/workqueue.h>

// Module parameters (these create files in
// /sys/module/RKKDR/parameters/)
static bool enable = false;
module_param(enable, bool, 0644);
MODULE_PARM_DESC(enable, "Enable the auto-clicker (1 = ON, 0 = OFF)");

static int interval_ms = 100;
module_param(interval_ms, int, 0644);
MODULE_PARM_DESC(interval_ms, "Interval between clicks in milliseconds");

// The virtual mouse device
static struct input_dev *vmouse_dev;

// The background worker that will fire the clicks
static struct delayed_work click_work;

// This function runs in the background and simulates the click
static void autoclick_worker_func(struct work_struct *work)
{
  if (enable && vmouse_dev)
  {
    // Send Mouse DOWN
    input_report_key(vmouse_dev, BTN_LEFT, 1);
    input_sync(vmouse_dev);

    // Small delay to simulate human click duration
    msleep(20);

    // Send Mouse UP
    input_report_key(vmouse_dev, BTN_LEFT, 0);
    input_sync(vmouse_dev);
  }

  // Safety limit: if the interval is too small, it could lock up the kernel
  // worker thread
  int safe_interval = interval_ms;
  if (safe_interval < 10)
  {
    safe_interval = 10;
  }

  // Schedule the next click (if enabled, otherwise sleep and check again)
  // Even if disabled, we keep the loop alive so it can wake up when 'enable' is
  // changed
  int wait_time = enable ? safe_interval : 500;
  schedule_delayed_work(&click_work, msecs_to_jiffies(wait_time));
}

int autoclicker_init(void)
{
  int error;

  // 1. Allocate the virtual input device
  vmouse_dev = input_allocate_device();
  if (!vmouse_dev)
  {
    pr_err("[[KRNL]AutoClicker]: Failed to allocate input device\n");
    return -ENOMEM;
  }

  // 2. Set the device properties
  vmouse_dev->name = "AutoClicker";
  vmouse_dev->id.bustype = BUS_VIRTUAL;

  // 3. Tell the OS this device has buttons, specifically the Left Mouse Button
  set_bit(EV_KEY, vmouse_dev->evbit);
  set_bit(BTN_LEFT, vmouse_dev->keybit);

  // 4. Register the device with the system
  error = input_register_device(vmouse_dev);
  if (error)
  {
    pr_err("[[KRNL]AutoClicker]: Failed to register input device\n");
    input_free_device(vmouse_dev);
    return error;
  }

  // 5. Start the background clicking loop
  INIT_DELAYED_WORK(&click_work, autoclick_worker_func);
  schedule_delayed_work(&click_work, msecs_to_jiffies(500));

  pr_info("[[KRNL]AutoClicker]: initialized. Disabled by default.\n");
  return 0;
}

void autoclicker_exit(void)
{
  // Stop the background worker
  cancel_delayed_work_sync(&click_work);

  // Unregister and free the virtual mouse
  if (vmouse_dev)
  {
    input_unregister_device(vmouse_dev);
    // input_free_device() is automatically called by unregister
    vmouse_dev = NULL;
  }

  pr_info("[[KRNL]AutoClicker]: safely shut down.\n");
}
