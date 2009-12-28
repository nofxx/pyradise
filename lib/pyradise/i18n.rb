module Pyradise
  module I18n
    I = {
    :en_us =>
      {
        :search => "Searching for",
        :order  => "Ordered by",
        :delete => "About to delete all the records. Sure? [y/N] ",
        :created => "products created"
      },
    :pt_br =>
      {
        :search => "Procurando por",
        :order  => "Ordenado por",
        :delete => "Deletar todo o banco? [y/N] ",
        :created => "produtos criados"
      }



    }

    def t(text)
      I[Options[:lang].to_sym][text.to_sym]
    end

  end
end
