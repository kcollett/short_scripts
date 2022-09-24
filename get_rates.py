#! /usr/local/bin/python3
#
#  -*- mode: python; -*-
#
import datetime
import xml.etree.cElementTree as ET
from abc import ABC, abstractmethod
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


class RootBuilder(ABC):
    @abstractmethod
    def getRoot(self) -> ET.Element:
        raise NotImplementedError


class UrlRootBuilder(RootBuilder):
    url: str

    def __init__(self, url: str):
        self.url = url

    def getRoot(self) -> ET.Element:
        page = requests.get(self.url)
        root = ET.fromstring(page.content)
        return root


class FileRootBuilder(RootBuilder):
    file: str

    def __init__(self, file: str):
        self.file = file

    def getRoot(self) -> ET.Element:
        tree = ET.parse(self.file)
        root = tree.getroot()
        return root


TREASURY_XML_NS: dict[str, str] = {
    # "https://home.treasury.gov/resource-center/data-chart-center/interest-rates/pages/xml"
    "d": "http://schemas.microsoft.com/ado/2007/08/dataservices",
    "m": "http://schemas.microsoft.com/ado/2007/08/dataservices/metadata",
    #  xmlns="http://www.w3.org/2005/Atom",
}
TREASURY_XML_PREFIXES: set[str] = set(
    {f"{{{value}}}" for value in TREASURY_XML_NS.values()}
)

TREASURY_RATE_XML_URL = "https://home.treasury.gov/resource-center/data-chart-center/interest-rates/pages/xml"
DATA_NAME = "data"
NOMINAL_DATA_VALUE = "daily_treasury_yield_curve"
REAL_DATA_VALUE = "daily_treasury_real_yield_curve"
DATE_VALUE_MONTH_NAME = "field_tdr_date_value_month"
BASE_NOMINAL_XML_URL = f"{TREASURY_RATE_XML_URL}?{DATA_NAME}={NOMINAL_DATA_VALUE}"
BASE_REAL_XML_URL = f"{TREASURY_RATE_XML_URL}?{DATA_NAME}={REAL_DATA_VALUE}"


def get_last_properties(root: ET.Element) -> ET.Element:
    """I could never get [last()] to work."""
    last_properties: ET.Element
    *_, last_properties = root.findall("*//m:properties", TREASURY_XML_NS)
    return last_properties


def get_filtered_children_text(
    element: ET.Element,
    namespace_prefixes: set[str],
    ignored_tags: set[str],
) -> dict[str, str]:
    filtered_elements: dict[str, str] = {}
    for child in element.iter():
        tag = child.tag
        # remove any namespace prefixes
        for prefix in namespace_prefixes:
            tag = tag.removeprefix(prefix)

        if tag not in ignored_tags:
            filtered_elements[tag] = child.text if child.text is not None else ""

    return filtered_elements


def get_properties_values(root: ET.Element) -> dict[str, str]:
    last_properties = get_last_properties(root)

    return_value = get_filtered_children_text(
        last_properties,
        namespace_prefixes=TREASURY_XML_PREFIXES,
        ignored_tags={"properties"},
    )

    return return_value

def print_as_csv(properties: dict[str,str]) -> None:
    print("NAME,VALUE")
    for name, value in properties.items():
        print(f"{name},{value}")


def main() -> None:
    """Simple main()"""
    # build URLs
    today = datetime.date.today()
    date_value_month = today.strftime("%Y%m")
    nominal_url = f"{BASE_NOMINAL_XML_URL}&{DATE_VALUE_MONTH_NAME}={date_value_month}"
    real_url = f"{BASE_REAL_XML_URL}&{DATE_VALUE_MONTH_NAME}={date_value_month}"

    nominal_builder: RootBuilder
    real_builder: RootBuilder
    debug = False
    if not debug:
        nominal_builder = UrlRootBuilder(nominal_url)
        real_builder = UrlRootBuilder(real_url)
    else:
        nominal_builder = FileRootBuilder("/Users/karencollett/treasury_nominal.xml")
        real_builder = FileRootBuilder("/Users/karencollett/treasury_real.xml")

    nominal_root = nominal_builder.getRoot()
    real_root = real_builder.getRoot()

    nominal_properties = get_properties_values(nominal_root)
    real_properties = get_properties_values(real_root)

    print_as_csv(nominal_properties)
    print_as_csv(real_properties)


if __name__ == "__main__":
    main()
