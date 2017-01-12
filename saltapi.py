#coding: utf-8

import urllib2
import urllib
import json
import sys

class SaltApi( object ):

    _token_id = ''
    def __init__(self,username,password,url):


        self._username = username
        self._password = password
        self._url = url.strip()

    def post(self, values, headers, prefix=""):

        values = urllib.urlencode(values)
        url = self._url + prefix
        req = urllib2.Request(url, values, headers)
        try:
            res = urllib2.urlopen(req)
        except Exception, e:
            print e
        res_data = res.read()

        content = json.loads(res_data)

        return content

    def token_id(self):

        logger.setLevel(logging.INFO)

        _headers = {
            "Accept": "application/json",
        }

        _values = {
            "username": self._username,
            "password": self._password,
            "eauth": "pam"
        }

        content = self.post(values=_values, headers=_headers, prefix="login")

        try:
            self._token_id = content["return"][0]["token"]
        except KeyError:
            raise KeyError
        return self._token_id

    def key_list(self):

        key_info = {}

        self.token_id()
        _values = {
            "client": "wheel",
            "fun": "key.list_all"
        }
        _headers = {
            "Accept": "application/json",
            "X-Auth-Token": self._token_id
        }
        _data = urllib.urlencode(_values)
        _req = urllib2.Request(self._url, _data, _headers)

        try:
            _res = urllib2.urlopen(_req)
        except Exception, e:
            print e
            logger.exception(repr(e))
            sys.exit(-1)
        _res_data = _res.read()

        _json = json.loads(_res_data)

        items = [
            'minions_rejected',
            'minions_denied',
            'minions_pre',
            'minions'
        ]

        for item in items:
            key_info[item] = _json['return'][0]['data']['return'][item]

        return key_info

    def deploy_module(self, tgt='', expr_form=''):

        self.token_id()
        _headers = {
            "Accept": "application/json",
            "X-Auth-Token": self._token_id
        }
        _values = {
            "client": 'local',
            "tgt": tgt,
            "fun": "state.sls",
            "arg": "zabbix_agent",
            "expr_form": expr_form
        }
        print _values
        content = self.post(values=_values, headers=_headers, prefix="")
        return content
