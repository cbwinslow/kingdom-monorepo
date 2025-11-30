"""
Web scraping and parsing tools for AI agents.

Provides tools for fetching web pages, extracting content, parsing HTML,
and extracting structured data from web pages.
"""

from typing import Dict, Any, List, Optional
import requests
from bs4 import BeautifulSoup
import re


def fetch_webpage(
    url: str,
    timeout: int = 30,
    headers: Optional[Dict[str, str]] = None,
) -> Dict[str, Any]:
    """
    Fetch a webpage and return its content.
    
    Args:
        url: URL of the webpage to fetch
        timeout: Request timeout in seconds (default: 30)
        headers: Optional HTTP headers dictionary
        
    Returns:
        Dictionary containing status_code, content, and headers
        
    Raises:
        requests.RequestException: If the request fails
    """
    if headers is None:
        headers = {
            "User-Agent": "Mozilla/5.0 (compatible; OpenAI-Tools/1.0)"
        }
    
    response = requests.get(url, timeout=timeout, headers=headers)
    response.raise_for_status()
    
    return {
        "status_code": response.status_code,
        "content": response.text,
        "headers": dict(response.headers),
        "url": response.url,
    }


def extract_links(html_content: str, base_url: Optional[str] = None) -> List[Dict[str, str]]:
    """
    Extract all links from HTML content.
    
    Args:
        html_content: HTML content to parse
        base_url: Optional base URL for resolving relative links
        
    Returns:
        List of dictionaries containing link text and href
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    links = []
    
    for a_tag in soup.find_all('a', href=True):
        href = a_tag['href']
        text = a_tag.get_text(strip=True)
        
        # Resolve relative URLs if base_url provided
        if base_url and not href.startswith(('http://', 'https://', '//')):
            from urllib.parse import urljoin
            href = urljoin(base_url, href)
        
        links.append({
            "text": text,
            "href": href,
        })
    
    return links


def extract_text(html_content: str, remove_scripts: bool = True) -> str:
    """
    Extract plain text from HTML content.
    
    Args:
        html_content: HTML content to parse
        remove_scripts: Whether to remove script and style tags (default: True)
        
    Returns:
        Extracted plain text
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    
    if remove_scripts:
        # Remove script and style elements
        for script in soup(["script", "style"]):
            script.decompose()
    
    # Get text and clean up whitespace
    text = soup.get_text(separator='\n', strip=True)
    
    # Remove excessive whitespace
    text = re.sub(r'\n\s*\n', '\n\n', text)
    
    return text


def extract_metadata(html_content: str) -> Dict[str, Any]:
    """
    Extract metadata from HTML content (title, description, keywords, etc.).
    
    Args:
        html_content: HTML content to parse
        
    Returns:
        Dictionary containing metadata
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    
    metadata = {}
    
    # Extract title
    title_tag = soup.find('title')
    if title_tag:
        metadata['title'] = title_tag.get_text(strip=True)
    
    # Extract meta tags
    for meta in soup.find_all('meta'):
        name = meta.get('name', meta.get('property', ''))
        content = meta.get('content', '')
        
        if name and content:
            metadata[name] = content
    
    # Extract Open Graph tags
    og_tags = {}
    for meta in soup.find_all('meta', property=re.compile('^og:')):
        property_name = meta.get('property', '')[3:]  # Remove 'og:' prefix
        og_tags[property_name] = meta.get('content', '')
    
    if og_tags:
        metadata['open_graph'] = og_tags
    
    # Extract Twitter Card tags
    twitter_tags = {}
    for meta in soup.find_all('meta', attrs={'name': re.compile('^twitter:')}):
        name = meta.get('name', '')[8:]  # Remove 'twitter:' prefix
        twitter_tags[name] = meta.get('content', '')
    
    if twitter_tags:
        metadata['twitter_card'] = twitter_tags
    
    return metadata


def parse_html(
    html_content: str,
    selector: str,
    extract: str = "text",
) -> List[Any]:
    """
    Parse HTML using CSS selectors.
    
    Args:
        html_content: HTML content to parse
        selector: CSS selector to find elements
        extract: What to extract (text, html, attribute name)
        
    Returns:
        List of extracted values
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    elements = soup.select(selector)
    
    results = []
    
    for element in elements:
        if extract == "text":
            results.append(element.get_text(strip=True))
        elif extract == "html":
            results.append(str(element))
        else:
            # Extract attribute
            attr_value = element.get(extract, '')
            results.append(attr_value)
    
    return results


def extract_tables(html_content: str) -> List[List[Dict[str, str]]]:
    """
    Extract tables from HTML content.
    
    Args:
        html_content: HTML content to parse
        
    Returns:
        List of tables, where each table is a list of row dictionaries
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    tables = []
    
    for table in soup.find_all('table'):
        table_data = []
        
        # Try to get headers
        headers = []
        header_row = table.find('thead')
        if header_row:
            headers = [th.get_text(strip=True) for th in header_row.find_all('th')]
        else:
            # Try first row
            first_row = table.find('tr')
            if first_row:
                headers = [th.get_text(strip=True) for th in first_row.find_all('th')]
        
        # Get rows
        for row in table.find_all('tr'):
            cells = row.find_all(['td', 'th'])
            
            if not cells:
                continue
            
            if headers:
                row_data = {}
                for i, cell in enumerate(cells):
                    header = headers[i] if i < len(headers) else f"column_{i}"
                    row_data[header] = cell.get_text(strip=True)
                table_data.append(row_data)
            else:
                # No headers, just use cell values
                row_data = {f"column_{i}": cell.get_text(strip=True) for i, cell in enumerate(cells)}
                table_data.append(row_data)
        
        if table_data:
            tables.append(table_data)
    
    return tables


def extract_images(html_content: str, base_url: Optional[str] = None) -> List[Dict[str, str]]:
    """
    Extract images from HTML content.
    
    Args:
        html_content: HTML content to parse
        base_url: Optional base URL for resolving relative image URLs
        
    Returns:
        List of dictionaries containing image src, alt, and title
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    images = []
    
    for img in soup.find_all('img'):
        src = img.get('src', '')
        
        # Resolve relative URLs if base_url provided
        if base_url and src and not src.startswith(('http://', 'https://', '//', 'data:')):
            from urllib.parse import urljoin
            src = urljoin(base_url, src)
        
        images.append({
            "src": src,
            "alt": img.get('alt', ''),
            "title": img.get('title', ''),
        })
    
    return images


def extract_headings(html_content: str) -> Dict[str, List[str]]:
    """
    Extract headings (h1-h6) from HTML content.
    
    Args:
        html_content: HTML content to parse
        
    Returns:
        Dictionary mapping heading levels to lists of heading text
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    headings = {f"h{i}": [] for i in range(1, 7)}
    
    for level in range(1, 7):
        tag = f"h{level}"
        for heading in soup.find_all(tag):
            headings[tag].append(heading.get_text(strip=True))
    
    return headings


def extract_forms(html_content: str) -> List[Dict[str, Any]]:
    """
    Extract form information from HTML content.
    
    Args:
        html_content: HTML content to parse
        
    Returns:
        List of form dictionaries containing action, method, and fields
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    forms = []
    
    for form in soup.find_all('form'):
        form_data = {
            "action": form.get('action', ''),
            "method": form.get('method', 'get').lower(),
            "fields": [],
        }
        
        # Extract input fields
        for input_field in form.find_all(['input', 'select', 'textarea']):
            field_info = {
                "type": input_field.get('type', 'text'),
                "name": input_field.get('name', ''),
                "id": input_field.get('id', ''),
                "required": input_field.has_attr('required'),
            }
            
            # Add options for select fields
            if input_field.name == 'select':
                field_info['options'] = [
                    option.get('value', option.get_text(strip=True))
                    for option in input_field.find_all('option')
                ]
            
            form_data['fields'].append(field_info)
        
        forms.append(form_data)
    
    return forms


def get_page_structure(html_content: str) -> Dict[str, Any]:
    """
    Get the overall structure of a web page.
    
    Args:
        html_content: HTML content to parse
        
    Returns:
        Dictionary containing page structure information
    """
    soup = BeautifulSoup(html_content, 'html.parser')
    
    return {
        "title": soup.find('title').get_text(strip=True) if soup.find('title') else '',
        "heading_count": {f"h{i}": len(soup.find_all(f"h{i}")) for i in range(1, 7)},
        "link_count": len(soup.find_all('a')),
        "image_count": len(soup.find_all('img')),
        "form_count": len(soup.find_all('form')),
        "table_count": len(soup.find_all('table')),
        "has_nav": bool(soup.find('nav')),
        "has_header": bool(soup.find('header')),
        "has_footer": bool(soup.find('footer')),
        "has_aside": bool(soup.find('aside')),
    }


__all__ = [
    "fetch_webpage",
    "extract_links",
    "extract_text",
    "extract_metadata",
    "parse_html",
    "extract_tables",
    "extract_images",
    "extract_headings",
    "extract_forms",
    "get_page_structure",
]
