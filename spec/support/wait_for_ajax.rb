module WaitForAjax
  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until finished_all_ajax_request?
    end
  end

  def finished_all_ajax_request?
    page.evaluate_script('jQuery.active').zero?
  end
end

