ActiveAdmin.register RegionalHoliday do
  permit_params :name, :day, :month, :company_id, office_ids: []

  index do
    column :company if current_admin_user.is_super?
    column :id
    column :name
    column :day
    column :month
    column :offices do |holiday|
      offices_by_holiday(holiday)
    end
    actions
  end

  show do
    attributes_table do
      row :company if current_admin_user.is_super?
      row :id
      row :name
      row :day
      row :month
      row :offices do |holiday|
        offices_by_holiday(holiday)
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :day
      f.input :month
      f.input :company_id, as: :hidden, input_html: { value: current_admin_user.company_id }
      f.input :offices, as: :check_boxes
      f.actions
    end
  end
end
