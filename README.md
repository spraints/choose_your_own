# Choose Your Own Adventure

The `choose_your_own` gem helps you define a multiple-choice
part of your view.

## Installation

Add this line to your application's Gemfile:

    gem 'choose_your_own'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install choose_your_own

## Usage

For example, let's say you want to let a user choose her avatar.
She can either upload a file or enter a URL. Inside of `form_for`,
add this:

```erb
<%= form_for :user, :multipart => true do |f| %>
  <%= f.choose_your_own :avatar_source do |x| %>
    <%= x.choice :url do %>
      <%= f.text_field :avatar_url %>
    <% end %>
    <%= x.choice :file_upload do%>
      <%= f.file_field :attached_avatar %>
    <% end %>
  <% end %>
<% end %>
```

The generated HTML will look like this:

```html
<div class="choose_your_own user_avatar_source_choices">
  <input type="hidden" name="user_avatar_choice" value="url" />
  <div class="choose_your_own_choice user_avatar_source_choice" id="user_avatar_source_url" class="active">
    <input type="text" name="user[avatar_url]" id="user_avatar_url" />
  </div>
  <div class="choose_your_own_choice user_avatar_source_choice" id="user_avatar_source_attached_avatar">
    <input type="file" name="user[attached_avatar]" id="user_attached_avatar" />
  </div>
</div>
```

Based on the current value of `avatar_source`, a different
choice will be marked with class="active". Note: if `avatar_source`
has no value, then none of the options will be active.

If you include our javascript, then clicking in one of the
divs will mark it as active.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
