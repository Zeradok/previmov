import re
import csv
from time import sleep
from unicodedata import normalize
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.common.exceptions import WebDriverException


def getimov(pags=10, cidade="pelotas", todas=False):
    firefox_capabilities = DesiredCapabilities.FIREFOX
    firefox_capabilities['marionette'] = True
    driver = webdriver.Firefox(capabilities=firefox_capabilities)
    url = 'http://www.zapimoveis.com.br/venda/imoveis/rs+' + cidade
    driver.get(url)
    data = [['preco', 'quartos', 'suites', 'vagas', 'area', 'bairro', 'tipo',
             'cidade', 'url']]
    pag = 1
    while pag <= pags:
        sleep(5)
        pag_url = driver.page_source
        soup = BeautifulSoup(pag_url, 'html.parser')
        page = soup.find(class_='pagination').input['value']
        if todas:
            pags = soup.find(class_='pull-right num-of').get_text().split()[1]
            pags = int(pags)
        aux = 0
        if int(page) != pag:
            aux += 1
            if aux > 5:
                print "Error timeout: data saved until page " + str(pag-1)
                break
            continue
        imoveis = soup.find_all(class_='caracteristicas pull-left')
        enderecos = soup.find_all(class_='endereco pull-right')
        for i in range(len(imoveis)):
            imovel = imoveis[i]
            endereco = enderecos[i]
            data_row = []
            price = imovel.find_all(class_='preco')[0].get_text()
            data_row.append(re.sub(r'R\$|\.', '',
                                   price).strip().split('\n')[0])
            try:
                quartos = imovel.find_all(class_='icone-quartos')[0].get_text()
                if re.match(r'^.*?(\d*)\squarto.*', quartos):
                    data_row.append(re.sub(r'(\d*)\squarto.*', r'\1', quartos))
                else:
                    data_row.append(u'')
            except IndexError:
                data_row.append(u'')
            try:
                suites = imovel.find_all(class_='icone-suites')[0].get_text()
                if re.match(r'^.*?(\d*)\ssu\xedte.*', suites):
                    data_row.append(re.sub(r'^.*?(\d*)\ssu\xedte.*', r'\1',
                                           suites))
                else:
                    data_row.append(u'0')
            except IndexError:
                data_row.append(u'0')
            try:
                vagas = imovel.find_all(class_='icone-vagas')[0].get_text()
                if re.match(r'^.*?(\d*)\svaga.*', vagas):
                    data_row.append(re.sub(r'^.*?(\d*)\svaga.*', r'\1', vagas))
                else:
                    data_row.append(u'0')
            except IndexError:
                data_row.append(u'0')
            try:
                area = imovel.find_all(class_='icone-area')[0].get_text()
                if re.match(r'^.*?(\d*)m2.*', area):
                    data_row.append(re.sub(r'^.*?(\d*)m2.*', r'\1', area))
                else:
                    data_row.append(u'')
            except IndexError:
                data_row.append(u'')
            try:
                bairro = endereco.findAll('strong')[0].get_text().strip()
                data_row.append(bairro)
            except IndexError:
                data_row.append(u'')
            try:
                tipo = endereco.findAll('p')[0].get_text().split()[0]
                data_row.append(tipo)
            except IndexError:
                data_row.append(u'')
            row = [normalize('NFKD', x).encode('ascii',
                                               'ignore') for x in data_row]
            row.append(cidade)
            imov_url = re.search("(?P<url>https?://[^\s]+)",
                                 str(imovel)).group("url").split("\"")[0]
            row.append(imov_url)
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
