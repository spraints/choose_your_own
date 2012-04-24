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
  <div class="menu">
    <div class="menu_item" id="menu_for_user_avatar_source_url"         data-value="url"        >Url</div>
    <div class="menu_item" id="menu_for_user_avatar_source_file_upload" data-value="file_upload">File Upload</div>
  </div>
  <div class="choice" id="user_avatar_source_url">
    <input type="text" name="user[avatar_url]" id="user_avatar_url" size="30" />
  </div>
  <div class="choice" id="user_avatar_source_file_upload">
    <input type="file" name="user[attached_avatar]" id="user_attached_avatar" />
  </div>
</div>
HTML
    assert_dom_equal expected, select(actual, '.choose_your_own'), 'example from the readome'
  end

  test "creates the hidden bookkeeping element" do
    form_for(@example) do |f|
      assert_dom_equal '<input type="hidden" name="example_model[name_type]" id="example_model_name_type" />',
        select(f.choose_your_own(:name_type){}, 'input')
    end
  end

  test "creates the hidden bookkeeping element with an initial value" do
    @example.name_type = "variety_a"
    form_for(@example) do |f|
      assert_dom_equal '<input value="variety_a" type="hidden" name="example_model[name_type]" id="example_model_name_type" />',
        select(f.choose_your_own(:name_type){}, "input")
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

  test "wraps the choice in a div" do
    form_for(@example) do |f|
      f.choose_your_own :name_type do |x|
        assert_dom_equal '<div class="choice" id="example_model_name_type_variety_a"></div>',
          x.choice(:variety_a)
      end
    end
  end

  test "sets the current choice as active" do
    @example.name_type = 'variety_a'
    form_for(@example) do |f|
      f.choose_your_own :name_type do |x|
        html = x.choice(:variety_a)
        assert_has_class 'active', html
      end
    end
  end

  test "yields for the choice's content" do
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

  test "produces a menu of choices" do
    form_for(@example) do |f|
      html = f.choose_your_own :name_type do |x|
        x.choice(:variety_a)
        x.choice(:variety_b)
      end
      expected =
        '<div class="menu">' +
          '<div class="menu_item" data-value="variety_a" id="menu_for_example_model_name_type_variety_a">Variety A</div>' +
          '<div class="menu_item" data-value="variety_b" id="menu_for_example_model_name_type_variety_b">Variety B</div>' +
        '</div>'
      assert_dom_equal expected, select(html, ".menu")
    end
  end

  test "uses custom text in the menu" do
    form_for(@example) do |f|
      html = f.choose_your_own :name_type do |x|
        x.choice(:variety_a, "AAA")
        x.choice(:variety_b, "bBb")
      end
      expected =
        '<div class="menu">' +
          '<div class="menu_item" data-value="variety_a" id="menu_for_example_model_name_type_variety_a">AAA</div>' +
          '<div class="menu_item" data-value="variety_b" id="menu_for_example_model_name_type_variety_b">bBb</div>' +
        '</div>'
      assert_dom_equal expected, select(html, ".menu")
    end
  end

  test "selects the current choice in the menu" do
    @example.name_type = 'variety_a'
    form_for(@example) do |f|
      html = f.choose_your_own :name_type do |x|
        x.choice(:variety_a)
        x.choice(:variety_b)
      end
      expected =
        '<div class="menu">' +
          '<div class="menu_item active" data-value="variety_a" id="menu_for_example_model_name_type_variety_a">Variety A</div>' +
          '<div class="menu_item"        data-value="variety_b" id="menu_for_example_model_name_type_variety_b">Variety B</div>' +
        '</div>'
      assert_dom_equal expected, select(html, ".menu")
    end
  end

  def assert_has_class(css_class, html)
    actual_class = HTML::Document.new(html).root.children.first['class'] || ''
    assert_include actual_class.split(/\s+/), css_class
  end

  def assert_dom_equal(expected, actual, message = '')
    expected = strip_empty_nodes(expected)
    actual   = strip_empty_nodes(actual)
    super expected, actual, message
  end

  def strip_empty_nodes(html)
    HTML::Document.new(html).root.tap{|node| strip_empty_nodes!(node.children)}.to_s
  end

  def strip_empty_nodes!(nodes)
    nodes.reject! do |node|
      case node
      when HTML::Text
        node.to_s.strip.empty?
      else
        strip_empty_nodes! node.children
        false
      end
    end
  end

  def select(html, selector)
    conditions = selector =~ /^\.(.*)/ ? {:attributes => {:class => /#{$1}/}} : {:tag => selector}
    HTML::Document.new(html).find(conditions).to_s
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
