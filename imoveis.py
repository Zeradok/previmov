import re
import csv
from time import sleep
from unicodedata import normalize
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.common.exceptions import WebDriverException   

def getimov(pags=10, cidade="pelotas"):
    firefox_capabilities = DesiredCapabilities.FIREFOX
    firefox_capabilities['marionette'] = True
    driver = webdriver.Firefox(capabilities=firefox_capabilities)
    url = 'http://www.zapimoveis.com.br/venda/imoveis/rs+' + cidade
    driver.get(url)
    data = [['preco', 'bairro', 'tipo', 'endereco', 'cidade', 'quartos', 'suites', 'vagas', 'area']]
    pag = 1
    while pag <= pags:
        sleep(5)
        pag_url = driver.page_source
        soup = BeautifulSoup(pag_url, 'html.parser')
        page = soup.find(class_='pagination').input['value']
        aux = 0
        if int(page) != pag:
            aux += 1
            if aux > 5:
                print "Error timeout: data saved until page " + str(pag-1)
                break
            continue
        imoveis = soup.find_all(class_='list-cell')
        for imovel in imoveis:
            data_row = []
            price = imovel.find_all(class_='price')[0].get_text()
            data_row.append(re.sub(r'R\$|\.', '', price).strip())
            data_row.append(imovel.find_all(class_='bairro')[0].get_text())
            data_row.append(imovel.find_all(class_='loc3')[0].get_text())
            data_row.append(imovel.find_all(class_='loc2')[0].get_text())
            data_row.append(imovel.find_all(class_='loc2')[1].get_text())
            try:
                desc = imovel.find_all(class_='inline loc2')[0].get_text()
                if re.match(r'^.*?(\d*)\squarto.*', desc):
                    data_row.append(re.sub(r'(\d*)\squarto.*', r'\1', desc))
                else:
                    data_row.append(u'')
                if re.match(r'^.*?(\d*)\ssu\xedte.*', desc):
                    data_row.append(re.sub(r'^.*?(\d*)\ssu\xedte.*', r'\1', desc))
                else:
                    data_row.append(u'0')
                if re.match(r'^.*?(\d*)\svaga.*', desc):
                    data_row.append(re.sub(r'^.*?(\d*)\svaga.*', r'\1', desc))
                else:
                    data_row.append(u'0')
                if re.match(r'^.*?(\d*)m2.*', desc):
                    data_row.append(re.sub(r'^.*?(\d*)m2.*', r'\1', desc))
                else:
                    data_row.append(u'')
            except IndexError:
                data_row.append(u'')
                data_row.append(u'0')
                data_row.append(u'0')
                data_row.append(u'')
            row = [normalize('NFKD', x).encode('ascii', 'ignore') for x in data_row]
            data.append(row)
        if pag != pags:
            btn_next = driver.find_element_by_id('proximaPagina')
            try:
                btn_next.click()
            except WebDriverException:
                print "Error loading url: data saved until page " + str(pag)
                break
        pag += 1
    driver.close()
    return data

def savecsv(data, dest='imoveis.csv'):
    with open(dest, 'wb') as f:
        writer = csv.writer(f, delimiter=';')
        writer.writerows(data)
