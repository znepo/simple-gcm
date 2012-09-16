# SimpleGCM
## A lightweight gem for using Google Cloud Messaging from Ruby

All sending is done through one method, `notify`. SimpleGCM does not implement retrying or exponential backoff, you can implement those yourself if you want them.

Notify takes an `array` of registration ids or a single registration id as a `string`. You should check the returned errors and check for updated registration ids.

```ruby
  response = SimpleGCM.notify registration_ids, 
    key: auth_key, 
    data: {
      message: "Hello World!"
    }

  response.each_error do |reg_id, error|
  end

  response.each_registration_id do |old_id, new_id|
  end
```

Available options to SimpleGCM.notify are

  *`collapse_key` - An arbitrary string (such as "Updates Available") that is used to collapse a group of like messages
  *`data` - A Hash whose fields represents the key-value pairs of the message's payload data 
  *`delay_while_idle` - If included, indicates that the message should not be sent immediately if the device is idle
  *`time_to_live` - How long (in seconds) the message should be kept on GCM storage if the device is offline
  *`dry_run` - Set to true and the GCM server will fake the response and not send a real message

The response object has some nice helpers so you don't have to deal with the raw json, but if you want it, it's there. Below are the supported methods.

  *`failures?` - Boolean, whether any of the messages failed
  *`results` - Hash of registration_id => result hash
  *`each_error` - takes a block, passes in |reg_id, error|
  *`each_registration_id` - takes a block, passes in |old_id, new_id|


For a better understanding of how this works and what each method is useful for, read the [GCM Server Documentation](http://developer.android.com/guide/google/gcm/gcm.html#server) and the Source.