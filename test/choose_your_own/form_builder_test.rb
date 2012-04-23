require 'test_helper'

class ChooseYourOwnFormBuilderTest < ActionView::TestCase
  setup do
    @example = ExampleModel.new
    @test_template_resolver = TestTemplateResolver.new
    @controller.append_view_path @test_template_resolver
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
    form_for(@example) do |f|
      f.choose_your_own :name_type do |x|
        @test_template_resolver.expect_render_partial("example_models/name_types/variety_a", :example_model => @example, :f => f) do
          x.choice(:variety_a)
        end
      end
    end
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

  class TestTemplateResolver < ActionView::Resolver
    def expect_render_partial(path, expectations)
      template = expected_partials[path] = ExpectedPartial.new(path)
      yield
      template.assert expectations
    end

    protected

    def find_templates(name, prefix, partial, details)
      [if partial && template = expected_partial(name, prefix)
        template
      else
        empty_template
      end.tap do |res|
        res.formats = details[:formats]
      end]
    end

    def expected_partials
      @expected_partials ||= {}
    end

    def expected_partial(name, prefix)
      name = "#{prefix}/#{name}" if prefix.present?
      expected_partials[name]
    end

    def empty_template
      ExpectedPartial.new 'empty'
    end

    class ExpectedPartial# < ActionView::Template
      def initialize name
        #super '(fake template)', 'fake template', ActionView::Template.registered_template_handler(:erb), {}
        @name = name
      end

      def locals=(*_) ; end # don't care
      # ActionView likes these things to be around:
      attr_accessor :formats, :virtual_path

      def identifier
        "Test Template #{@name}"
      end

      def render view, locals
        @view = view
        @locals = locals
        @rendered = true
        ''
      end

      def assert expectations
        assert_rendered!
      end

      def assert_rendered!
        fail "Template #{@name} should have been rendered!" unless @rendered
      end
    end
  end
end
