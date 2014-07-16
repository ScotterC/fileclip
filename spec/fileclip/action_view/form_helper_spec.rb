require 'spec_helper'

describe FileClip::ActionView::FormHelper do
  let!(:form) do
    if rails_4_1_x?
      ActionView::Helpers::FormBuilder.new(:image, nil, nil, {})
    else
      ActionView::Helpers::FormBuilder.new(:image, nil, nil, {}, nil)
    end
  end

  let(:helper) do
    ActionController::Base.new.view_context
  end

  describe "#fileclip" do

    describe "without options" do
      it "is an input tag" do
        regex = %r{\A<input.*/>\z}
        expect(form.fileclip(:attachment)).to match regex
      end
    end

    describe "with options" do
      it "has class attribute" do
        attribute = %{data-button-class}
        expect(
          form.fileclip(:attachment, "Submit", class: 'btn')
        ).to include attribute
      end

      it "has text attribute" do
        attribute = %{data-button-text}
        expect(
          form.fileclip(:attachment, "Button Text")
        ).to include attribute
      end

      it "has id attribute" do
        attribute = %{data-button-id}
        expect(
          form.fileclip(:attachment, "Button Text", id: "login-button")
        ).to include attribute
      end

      it "has an activate option" do
        attribute = %{data-activate}
        expect(
          form.fileclip(:attachment, "Button Text", activate: false)
        ).to include attribute
      end
    end

    describe "with a block" do
      before :each do
        # Not cool
        form.instance_variable_set("@template", ::ActionView::Base.new)
      end

      it "appends the block yield" do
        expect(
          form.fileclip(:attachment) do
            helper.content_tag(:p, "Hello World")
          end
        ).to include "<p>Hello World</p>"
      end
    end

  end

end