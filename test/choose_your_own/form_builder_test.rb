require 'test_helper'

class ChooseYourOwnFormBuilderTest < ActionView::TestCase
  setup do
    @example = ExampleModel.new
  end

  test "readme" do
    actual = render :inline => <<ERB
<%= form_for :user, :url => '/example', :multipart => true do |f| %>
  <%= f.choose_your_own :avatar_source do |x| %>
    <%= x.choice :url do %>
      <%= f.text_field :avatar_url %>
    <% end %>
    <%= x.choice :file_upload do%>
      <%= f.file_field :attached_avatar %>
    <% end %>
  <% end %>
<% end %>
ERB
    expected = <<HTML
<div class="choose_your_own user_avatar_source_choices">
  <input type="hidden" name="user[avatar_source]" id="user_avatar_source" />
  <div class="choose_your_own_choice user_avatar_source_choice" id="user_avatar_source_url">
    <input type="text" name="user[avatar_url]" id="user_avatar_url" size="30" />
  </div>
  <div class="choose_your_own_choice user_avatar_source_choice" id="user_avatar_source_file_upload">
    <input type="file" name="user[attached_avatar]" id="user_attached_avatar" />
  </div>
</div>
HTML
    actual = HTML::Document.new(actual).root.children.first.children.last.to_s # -> the <div> of intereset
    assert_dom_equal expected, actual, "example from the readme"
  end

  test "creates the hidden bookkeeping element" do
    form_for(@example) do |f|
      assert_dom_equal '<div class="choose_your_own example_model_name_type_choices"><input type="hidden" name="example_model[name_type]" id="example_model_name_type" /></div>',
        f.choose_your_own(:name_type) { |x| }
    end
  end

  test "creates the hidden bookkeeping element with an initial value" do
    @example.name_type = "variety_a"
    form_for(@example) do |f|
      assert_dom_equal '<div class="choose_your_own example_model_name_type_choices"><input type="hidden" name="example_model[name_type]" id="example_model_name_type" value="variety_a" /></div>',
        f.choose_your_own(:name_type) { |x| }
    end
  end

  test "calls block" do
    ok = false
    form_for(@example) do |f|
      f.choose_your_own :name_type do |x|
        ok = true
      end
    end
    assert ok, "f.choose_your_own should call the provided block"
  end

  test "wraps the element in a div" do
    form_for(@example) do |f|
      f.choose_your_own :name_type do |x|
        assert_dom_equal '<div class="choose_your_own_choice example_model_name_type_choice" id="example_model_name_type_variety_a"></div>',
          x.choice(:variety_a)
      end
    end
  end

  test "sets the element as active" do
    @example.name_type = 'variety_a'
    form_for(@example) do |f|
      f.choose_your_own :name_type do |x|
        assert_dom_equal '<div class="active choose_your_own_choice example_model_name_type_choice" id="example_model_name_type_variety_a"></div>',
          x.choice(:variety_a)
      end
    end
  end

  test "renders a template for the option" do
    ok = false
    form_for(@example) do |f|
      f.choose_your_own :name_type do |x|
        x.choice(:variety_a) do
          ok = true
        end
      end
    end
    assert ok, "Expected x.choice to yield"
  end

  def example_models_path(*_)
    '/does/not/matter'
  end

  class ExampleModel
    include ActiveModel::Conversion
    def persisted? ; false ; end
    def self.model_name ; ActiveModel::Name.new(self, nil, 'ExampleModel') ; end

    attr_accessor :name_type
  end
end
