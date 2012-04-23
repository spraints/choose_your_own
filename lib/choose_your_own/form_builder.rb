require 'action_view'

module ChooseYourOwn
  module FormBuilder
    def choose_your_own method, &block
      builder = ChoiceBuilder.new(self, method)
      @template.content_tag :div, :class => "choose_your_own #{@object_name}_#{method}_choices" do
        hidden_field(method) + @template.capture(builder, &block)
      end
    end

    class ChoiceBuilder
      def initialize form_builder, category_method
        @form_builder = form_builder
        @category_method = category_method
      end

      def f               ; @form_builder                                      ; end
      def template        ; @form_builder.instance_variable_get(:@template)    ; end
      def object_name     ; @form_builder.instance_variable_get(:@object_name) ; end
      def object          ; @form_builder.instance_variable_get(:@object)      ; end
      def category_method ; @category_method.to_s                              ; end
      def selected        ; @selected ||= ActionView::Helpers::InstanceTag.value_before_type_cast(object, category_method).to_s ; end

      def choice(method, &block)
        block ||= lambda {}
        template.content_tag :div, :class => "#{method.to_s == selected ? 'active ' : ''}choose_your_own_choice #{object_name}_#{category_method}_choice", :id => "#{object_name}_#{category_method}_#{method}", &block
      end
    end
  end
end

ActionView::Helpers::FormBuilder.send :include, ChooseYourOwn::FormBuilder
