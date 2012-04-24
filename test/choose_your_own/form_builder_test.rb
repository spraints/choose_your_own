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
  end if ENV['SADISTIC']

  test "creates the hidden bookkeeping element" do
    form_for(@example) do |f|
      assert_select_html f.choose_your_own(:name_type){}, "input", :count => 1 do |selected|
        input = selected.first.to_s
        assert_dom_equal '<input type="hidden" name="example_model[name_type]" id="example_model_name_type" />', input
      end
    end
  end

  test "creates the hidden bookkeeping element with an initial value" do
    @example.name_type = "variety_a"
    form_for(@example) do |f|
      assert_select_html f.choose_your_own(:name_type){}, "input", :count => 1 do |selected|
        input = selected.first.to_s
        assert_dom_equal '<input value="variety_a" type="hidden" name="example_model[name_type]" id="example_model_name_type" />', input
      end
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
        assert_select_html x.choice(:variety_a), 'div', :class => 'active choice', :count => 1
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
      assert_select_html html, 'ul', :count => 1 do |selected|
        ul = selected.first.to_s
        expected =
          '<ul class="menu">' +
            '<li id="example_model_menu_name_type_variety_a">Variety A</li>' +
            '<li id="example_model_menu_name_type_variety_b">Variety B</li>' +
          '</ul>'
        assert_dom_equal expected, ul
      end
    end
  end

  test "uses custom text in the menu" do
    form_for(@example) do |f|
      html = f.choose_your_own :name_type do |x|
        x.choice(:variety_a, "AAA")
        x.choice(:variety_b, "bBb")
      end
      assert_select_html html, 'ul', :count => 1 do |selected|
        ul = selected.first.to_s
        expected =
          '<ul class="menu">' +
            '<li id="example_model_menu_name_type_variety_a">AAA</li>' +
            '<li id="example_model_menu_name_type_variety_b">bBb</li>' +
          '</ul>'
        assert_dom_equal expected, ul
      end
    end
  end

  test "selects the current choice in the menu" do
    @example.name_type = 'variety_a'
    form_for(@example) do |f|
      html = f.choose_your_own :name_type do |x|
        x.choice(:variety_a)
        x.choice(:variety_b)
      end
      assert_select_html html, 'ul', :count => 1 do |selected|
        ul = selected.first.to_s
        expected =
          '<ul class="menu">' +
            '<li class="active" id="example_model_menu_name_type_variety_a">Variety A</li>' +
            '<li id="example_model_menu_name_type_variety_b">Variety B</li>' +
          '</ul>'
        assert_dom_equal expected, ul
      end
    end
  end

  def assert_select_html html, *args, &block
    assert_select(HTML::Document.new(html).root, *args, &block)
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
