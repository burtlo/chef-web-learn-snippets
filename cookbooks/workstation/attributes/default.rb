default['products']['versions'].tap do |product|
  product['virtualbox']['debian'] = '5.0'
  product['virtualbox']['windows'] = '5.0.24.108355'

  product['vagrant']['debian'] = '1.8.4'
  product['vagrant']['windows'] = '1.8.4'

  product['chefdk']['debian'] = "stable-0.16.28"
  product['chefdk']['rhel'] = "stable-0.16.28"
  product['chefdk']['windows'] = "stable-0.16.28"
end
