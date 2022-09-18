#! /usr/bin/python3
#
#  -*- mode: python; -*-
#
import datetime
import xml.etree.cElementTree as ET
from dataclasses import dataclass

import requests


@dataclass(frozen=True)
class Rates:
    """Class representing a particular set of treasury yields."""

    date: datetime.date
    r5y: float
    r10y: float
    r20y: float
    r30y: float


TREASURE_RATE_XML_URL = "https://home.treasury.gov/resource-center/data-chart-center/interest-rates/pages/xml"
DATA_NAME = "data"
NOMINAL_DATA_VALUE = "daily_treasury_yield_curve"
REAL_DATA_VALUE = "daily_treasury_real_yield_curve"
DATE_VALUE_MONTH_NAME = "field_tdr_date_value_month"
BASE_NOMINAL_XML_URL = f"{TREASURE_RATE_XML_URL}?{DATA_NAME}={NOMINAL_DATA_VALUE}"
BASE_REAL_XML_URL = f"{TREASURE_RATE_XML_URL}?{DATA_NAME}={REAL_DATA_VALUE}"


def find_all_ending_with(element: ET.Element, tag: str) -> list[ET.Element]:
    return [child for child in element if child.tag.endswith(tag)]


def find_only_one_ending_with(element: ET.Element, tag: str) -> ET.Element:
    child_elts = find_all_ending_with(element, tag)
    assert len(child_elts) == 1
    return child_elts[0]


def get_last_entry(root: ET.Element) -> ET.Element:
    last_entry: ET.Element
    entries = find_all_ending_with(root, "entry")
    for elt in entries:
        last_entry = elt

    # *_, last_tr = soup.find_all("tr")
    return last_entry


def extract_date_from_element(date_elt: ET.Element) -> datetime.date:
    date_str = date_elt.text.strip()
    dt = datetime.datetime.strptime(date_str,"%Y-%m-%dT%H:%M:%S")
    return dt.date()

def extract_rate_from_element(rate_elt: ET.Element) -> float:
    return float(rate_elt.text.strip()) / 100


def extract_rates_from_properties(properties: ET.Element) -> Rates:
    date: datetime.date = None
    r5y: float = 0.0
    r10y: float = 0.0
    r20y: float = 0.0
    r30y: float = 0.0

    for child in properties:
        if child.tag.endswith("DATE"):
            date = extract_date_from_element(child)
        elif child.tag.endswith("5YEAR"):
            r5y = extract_rate_from_element(child)
        elif child.tag.endswith("10YEAR"):
            r10y = extract_rate_from_element(child)
        elif child.tag.endswith("20YEAR"):
            r20y = extract_rate_from_element(child)
        elif child.tag.endswith("30YEAR"):
            r30y = extract_rate_from_element(child)

    return Rates(date, r5y, r10y, r20y, r30y)


def get_rates(url: str) -> Rates:
    page = requests.get(url)
    root = ET.fromstring(page.content)

    last_elt = get_last_entry(root)
    content = find_only_one_ending_with(last_elt, "content")
    properties = find_only_one_ending_with(content, "properties")
    return extract_rates_from_properties(properties)


def main() -> None:
    """Simple main()"""
    # build URLS
    today = datetime.date.today()
    date_value_month = today.strftime("%Y%m")
    nominal_url = f"{BASE_NOMINAL_XML_URL}&{DATE_VALUE_MONTH_NAME}={date_value_month}"
    real_url = f"{BASE_REAL_XML_URL}&{DATE_VALUE_MONTH_NAME}={date_value_month}"

    nominal_rates = get_rates(nominal_url)
    real_rates = get_rates(real_url)

    print(nominal_rates)
    print(real_rates)


if __name__ == "__main__":
    main()
