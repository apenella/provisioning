# continuous_delivery-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['continuous_delivery']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### continuous_delivery::default

Include `continuous_delivery` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[continuous_delivery::default]"
  ]
}
```

## License and Authors

Author:: Aleix Penella (aleix.penella@gmail.com)
